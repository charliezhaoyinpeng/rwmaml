��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2171084717488qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2171084717008qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2171084718352qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2171084718832q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2171084717296q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2171084721328q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2171084717008qX   2171084717296qX   2171084717488qX   2171084718352qX   2171084718832qX   2171084721328qe.(       ��h p�c���3b��V%d>M?����#H>�fd���?Ue=��!��>������j��h�����I���	ƾ�g[?w�{��I?KS��K?�&�>�P�>`{(�<����=���EL��i�=n�	?Z��>�9����H�''�=)����?(       s?�)�?<�s=�H/>�=f?=�[?���>q̓��a�=�=�٘������K�D�i�����18?h��CȾ�@?p���ͪ0=O�>��?��ν�)�=��6��
>29�3��>r\}���>A�/?���;N!w�-t�=.0�=f葽S��>��i�(       1ٙ�Ez��<�?�W3?�
��B���?H~<���>\Ͼ`?�<@F�<&9��?���>h/->��N��-�>��>~��=̬?����:�������-�>[#?sr_����>+}T��ݾmp�>e־�v�����>�7?��� ?6�,?���@      S�M�r���j���A�=q�����?}�H��D��>o�= �<���>�ƴ=P���Q�<�	��ԁ�=vؾ.�/=NB9?a�L?�����̾=7�;����QJ��C��=�\>^9�.&5>`?)�l	���v�;`=��L�el�Z$���O@�:��=0ޫ��w��d��,>���)���.��֨�ٯg?�ӑ�2�Y�n����>)*H�6��={l$�TĽc�=*ᦽ��j�o����߽�H�ޞ�<,�	>���f>���;�?�⾚��Q�6>\�i�9ϧ��@<>gn�=)�mH>!�3�)VW��WL��2#�NM1>
`��>=`%��$�Q�� j��ޖ�[w>b���^%Ž�S�=d�=���<K3>�ް=)y>@m\;�˽ܹ̽`.��[������Z��ƒ�=� ����=r-�=�Ɗ�p���
��J�<x�J��u�\��1e��H�)P����!��>|sU����>�P2?��Z���P>�J���#���t>�ق?H���C���K?C?�� >h�E=��>�=$���q�>�#>&O���_��z>��tR�>#���[��M�C�.>9�>d�ü�0]>sh���λVΏ��3�?7���>���>!�.=�(��H؎�,�ľIb��U�=���;��Ҿ��?��\RH���=�ɽ��>|�F=L偿̂��!D����<0�l]�X!�>&�?�&���?��f���G�Mi(��C>��=
Uؾ}���lp�����j罜<�]{̾��h��Z}�1�'>nBa;������p��B�[�H=J��NҴ?H?�`Ɣ�v��=;ZN=��>���;�Ƞ�Wn޽��u��F���L�E�νCp/?QO?w뢾/����]��F)��]����>Ͱ�=�tþ�W	=��!���׾F�>�[-�0C���諽���Y"�F Y>��ʻ����K*�V˂�V�C>J쵼���B���ܧ�>�E�?�5>���=@�/?��?�#��]�<�B>�(ܽEH�>fhs>�3x��Q?eH�>.ڷ>���=[:�� x��S��Z��=}�>�L���K�����'��s)�X�>3\��?T��&�n���K>���u��>׹�����A�J1�<|5^�xӀ��ȡ��8�.[->=9���ν��%=|ڽ�o}��ݽS.?u,���u���D�O��>Է׾;M?�����������ϼoV�=ކg>.{>W�M;�ZT>ё�={4?�?���>�v�=��>L�?���=|VH?�!?�@��=�� �G�7bV��_b�_Β��+����ξ�`@0��U������|���>fj�?�y`�����p�?r^��g-��P�\?_V��@�h�2@|CB�M:?`J@q�>_�����@T�B��-?
6�?:f[�?�>��@
<�[�e��:a�6�JL��H#�=���=U�D=��=���='3����=�ҽ`��;�d#����=+�ٽ0xq=sؑ���=0�/�6�ǽ�T署~��:��&<���=t�1=s��V��������(�=�"�"��=zWi��������>���t�����=~�w��<����_!>}#�=F��F��3��G<�<�����<�0�=�>�Z�2��c�;I%��ܼ�l�Y�}=\��>���k+��hM(���:�K���oH�g�</")�T�/=?����;|�=��,���D(�=�-���<�����X�	�2���c�~�ĽPD;>L�>�:�=�5�=�'r>�?K鎼:���`����!�Sdݽ��>�"� $�;��O��j����g�D�`>���>�K����<`����!g����.���2m��-�V�B��Zt�FhW����@k�=�5�=���>�t�=V:<�i:��������佗�<������=�ѽ��W=,�?��I�͊l>@�)�>Kכ��藾^�k��y>K�½�������6�@�1y��>�yž\d4>� ��Z��'�م?�6�>��H��A�R��+�N�<?ȧ��z���f>�҅�Ӓ	�$��=�r=j�=zv�����n��+�ǽo�ox�pL�<ܖ�� �:�W��\C<�R>��������N 6� ���N�=T�=�Eս 58�H��>��#��$�D=�<��Z��=V2�=��@g��ٽ@b�=���=����,�=�u����&;O>��������\�x�7�bq�=�}�=�V�� �Y�+��?����^�>�{ѿPvx=]�Q;_��,a5=k-!�޹þ��l�0�B��̿Fd�=��j>Y(��H�>��=�W(�.�ؽ�����p�@���vZ�����q�#>�.�?~�뿸kK=р^�?�"���Q���>D@���!�� ��Ѽ�7��n�?�=��}����=�Ѿ���ľ��5<�\d��>���nt�:��=>4����R&0?G?~b��d��=��y�x2=��H����>�j�	Q뾦˄�j�H�Z'A���.>�*ܾ&.��9G�����;zѾgX���s���I��#i>5���#����=Pꐽ�.̽�K�=��K����!M۽"b;�� � >=#e��[�F�:�۽84=��}=��=���|H,������R=���חA���"=��ʽ���/�"�y�-�-�齟MN���ν��>}�a�(��_*��>��"=����v�>�����#����j�Ӊ�=@��?���g�=4��?���=��e��YU��y��x��<������Xp��}�?�0���Z&>~4Y�`�>ȖپxH�:�-=2v��N ���Ϳ���D'��-H��cn@gs
��Ƚ��4��޿�0��6?��(��u4��<�<�Q����?�K?St?�0�.�8=m�5z>q��>`R����!��ۗ���<-��e��� �9�@�X݈:4?a����>Z�>��?:⽼3�����S���>I��=�Î>���<~'�rE'���x�A��U�� b
>�|B�h�
�
Cy=ծ=p�V=�ۋ�����3��������;���;�I�o)=l�=3�!>�~����={�>]� >z����T)�������ս�o��l�>��K>~ߋ���½9��p&�=�EN>à1�^Fx�(�l�_Я��:��e�=��k�>�T�.�s����=��=��5�K^���h=F����}��J�W>"��7���ڼk!��=�y�=�uQ�~�?�W������������=���AV��k�>���=h�����=������l����=�A��o��|=q�tQ�y���=|��=�kb���s�f� �!6>��>���N}�6�>ݬ�?���NI�>���>�����\��r">=��>�nl�;>���>�wf��Q?��>�(n?A���ع���{��p
���AZ��۽bA�ɠ��y:���T��G`�=>�*<��>���
ݽ�N>���P�߽lſ=F��������92?`��[��k��/��=��y�?+��t�v���6>�����o��q�����v�=�>mǼ �����=߆ʽ��>S�x�:��`|�]e��S�{�jR�>/Ͻ�u��<�:
�/`	��>��ǭ�oЊ>:�?�%~�=��_>(�<���=&�>8ɲ>����,���˽lW���ڭ��� �G��= GѼ�`�<�e>��z����<7�>�澣5����z; ����ϾߕD�a�R=��潥�=��ٽ�y����=9��=�ߤ�2-�>�
�
�e��?>�|���r'=.md=�~ѽ�7^�ox���.)�~h,�Yd=�vp��
��N��#<��+�=l��I|��0�`=���:cH����^����EN��8���<��9=y����j��>M������4,�Ȼ��b��'��뽻$^=.E!��θ�K߲:�w������<��ξJcE:d�=ڏ�=f����O~=MV����-?�?�=��=}b:���\=J� >����f|�� =�\����(��=�����#��ұ=�eƾA���o�<@�8�'> ҉��l������8��o���5>�[?�o�ބ���Eپ��������>Ԕ?��?����Z�B�+�ў$�-!����>���?�;��?d�=W&����Il�p�o<Y`W?Ht����> 8?�I��mq��K&?ZҾȐ;��>:7��ݢ
?�B�>��>�煾{�>{>ž�c1?a�=�F�,�>��>��o����q,��m��;v��P�f���=f�6��0��᥻:�[��;�p��L��sս��j�S𼐨=�'�����`.2�/
���ӽAS�H�;S��=��r�Z����t 0�����(�!=N�3=�񒾨��=�;K����
�䨝=@�h�2Vj���罺k�>�;�>�]%�SZ��?e=�����"�=���?���QM�/}<?D.[=���<� ׽~9�<R��=vh1?ϝ��i>�B�u����_ǾU�??��%������@�Dpd<�?A�;�H���g�V0>��9=��?;��K>�<9>�5���yo�Ҽ�r?!�ݿ�3�];��E�>g	y�CU��PZU�Eb[��[�=��O?X����옾G�2�ݾ"��Y��W?P�l���t����~�hD!? �?��ӾI%=P��>��B� ?�	a?�/�>+
Z>�u?Q�1��4
���l?���Y ��	��?�+���3���������)�u鴼Ѧ���11��c>���?�#���a&=6�>P�Ͻ���du>O{I>l2X�:i<υ�<
�c��r�?�׾>��>���=��1�i~\�a�j�����bO��4B�4������%I��ײ>��[=2P�>	l
�)��<���=1�b�/�a������	�-0g�t���A?8� >|#�����>�7��ſ�ov��Z��KS����ƽT����9���'�>������?�?�K���>a[>���?X����J�����6s��t���o?��{>�-n�G�������}���y���J�A�=�P�=r��<�d=�Q<���;u<�����i��:��;�!j��[6>I>��}���<��= +)�z~�=��>�yj?�݌�$���#Ϳ����Լ1��×=r�>��>����Q��=��#�$`��Z3�=����?��-��s�����GϽ�>��1��֪��2�}�}=eR�=�;ּ�����9�a��Bj�<�M�4L�p��*�V���<Ѷ4>�\="Rҽ�e�<tk>�����''�����K[ >KF���<����	?�9=��4=5�@�A�=3�,���>c�^��d��7�<�<��A��ˍ>����&>���v��r�Q�q=X�̼��ݽ֐!�LjR=��)�M
>A��=*��<`�<wos<�}=4 �̮;=q:�=|ݽ���Xa�p���,�R<ɼ���>����<��&�$�ѽ"g�=��=��b<���v����rڽ��=�MV=��=�?�=_V������[X=8��<��@b�=8uG�m���K>��1=���=���=����P)t<�� >0������޽&�/�W
>��&c]��;=��ֵ�=�Ὣh> o�;z@�=��½�$:����<�N���E�=D�����X��<
9���=؎�h��(��c���'2�Ti�ا���6��־q>��뿼�!<??	�p�>�
ν�6.�y�o�F67���ƽ~GĽP��<d��>f���c��>�i�0>*h־��=�PV�>F��E`���=�=� �=�fX>ft���ݡ�c�2>���=���Ty�=���?��0�Ҟ?2�A��D��\t�'�H��@>��(?����O��=���p�B<ǡ=�y��㳼���=��%��;�	6U�D彞��<m���˘����>�01�'{%��WB=�����<���oÅ�@�G�M��;|~���/u����t��P�����ɐ�>^3�&����4>Q��=��i��;,��=���?,h>�m}>Cj�>���<��@�v>?�L>Q7>�6��UW��z�`_P?�Ĳ>�G5?"��ŶA�Z~��4Fľ�L>*����=g����B����z�B݄��s�>�>�d�=/ƾ�[p��s>��}�1*ʼ\��<e��<|v>Ȟ�]{E�Q�\kH�\�>�ro�ȁ
��o��*%=�>=!C>p�Y<pM�v��<���>Fq��W�Ee�����u��MS�=���<	C9>[�<h"��<���>��=��߽�=��|P=5J̼$씾嚜��)�=�G�=}VZ�(       1�<��G> �(=��D��a����&�k_1�ծ�>v�	>#���e\���ؾ�?���n�&?�:m=wP����?�^?f�>%]|>IU;Di\>	:"��꒽\�>e;徜_���$q�R?θϾ��>i��=�3?N�:�`��<qhJ> ��>j�*���       2ƿ