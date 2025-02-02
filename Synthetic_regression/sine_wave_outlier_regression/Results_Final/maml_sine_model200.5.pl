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
qBX   2327161781392qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2327161780336qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2327161781488qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2327161781584q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2327161781680q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2327161777360q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2327161777360qX   2327161780336qX   2327161781392qX   2327161781488qX   2327161781584qX   2327161781680qe.       '�M�(       Ǒ�&��=��ѿ���F�Y=���>����ʁ=�����o�>�x3?��!�,�=U������h��¿T4�nG���]>X���F�?O��C�>���=_�RԔ�΢@�j2�#�l8�=�6�6s�>����V�e�ÿ�`N;)����ֿ�>(       ��o���M= �?"7#?��#��jh�� ?c�ɼ���>�60�R�ͽ@F�<��B���?{�>h/->�(_�0?�>!N">������>�G�Ǽ!���R���/��-q=%��>��\�#��>��Mk��Q>"�5�J��L>��>?Ⱦ�t�>�r?��@      �����f��Y諾�E>R|�>Hk>��3��J��{�u��v׽�� ��ƴ=�A7?[`q<Ni�=ԁ�=�5�����<���Ӣ'?�l�����
B��R�=���B ��s�N>;�6��w�>RaE�j�V?��=+�=��%�z��<����5�?H2�<��N��;�?�����!?T�4�@y��p�ݾ[4$>e\����+�"����Ö;�޼?6��=��>ڎT�Ic�*ᦽ	�ʱ;����?�_?R&���1���	��n�ҽ��п 3���y��G�#�ي=�G��J���/�vf��
�	�Z�L�u����{��m��OJ �
`�v���`%��$�Q��]��ޖ��|�=b���4�X��1	�d�=���<K3>�ް=)y>@m\;K���%����[��<�L��Z���Xa�� ��X;<r-�=�Ɗ�8F�
��J�<��0��yu�\���	p��H�)P������>�)��F�΋?�l�=Bm>:*1��_��p�e4��۴�>h�̽'9?�� >97���d�>��)?$����=��K>���)�ʾ�p���*a���a��� ��(�<2H�>/n3���L˽�C�ߠ��]��w���3�= 5c?k�=��>�>������Y<��>2��>��=ߩ������_�>���?��=~�׽X���|�F=���=�<b��>���<z�	?
C�=��ǾB䕾2�]?�h\>-�>Y}սO����=Z�>X�<>Q(��4`�o���3�佱��;o(Ⱦ��=���>�m7>��D>'c�>�pG��$羝ے���g=/t>���>}n�>yIf�����o>!X�=q������;���>�������F��{x����ؼ
�">s��>I���t��l��:o>��T?�=�
�3>��E�i�=�M��>9Y�>����j�>�#�?B��V���7�>{ =Y��=�[�=�)��Ⱦ>�>\c����=��I��
�>/M<�]>%�UI;��?�gX����=I3�>�(ܽ�Z�
��=j;]�s�/��'?��>"���-���'_����>d(�<$(�9>�<�+����Z:=D��<��'��~"?��ļy'��>Cs
�տ��H�?�1�����%5I>�=DI���0�>��'� =>T�p���ν)hD>'F>��E���ݽ��>I�^�A�`�PA�<���G�=��N?:@Z��)�=�1�>�������jCP?�m�>V�=�?
`Q>�8�=���>���ꄭ>�R?����=�ڔ>�E>�f����aÐ��9g�ϸؿ�,c��~�Ď��Tl�>0���N=>�1������>hb�?�3?��++>|��Y�!�L?�#�><p�\�L?l{��afh�4��?E)>>�>G\(?�?�2���A��?�x��8�>�k�?��m�N_ܾ�?���V�����>���<����/�3>�=��ڽ��:�)/�`��;~��<[�r>M�0xq=��N?��W>� D?9dB�^k�Д�ٳ�?����@�=CjQ>'�X���A��9nF?��=���>4z� ��?e[�z2�^�پ��=d>��^��.�x��>��+>3F>�YC�)u4�[�}>K���̽첋� DL?�>�"b?��C=|�G��ܼ���W��=�9>\HĽj��M	���X���*�E�8���C�l �=^e���t����aˑ�r�)<��s����<���.��q�8�Iq=�״�-��ͬʿ;1>S�<?�X�s?g&D=�r��r�@����>G����!��F����=4�� $�;>Z���q;W��׈s�V�>kɰ��ȭ���k>L=�<T�����u=��uB��i'���4��Ce�3��>/4D�5>NI�>��ž^�>� �=3�.?��b��>]����5���i���7ο��l>��̾t_�<�Hʾ)�>x��� W-�>(��y>#��<��9��2dᾞK��Y\>_�����nX���|��ȍ��d�=� ���k�;��C���������'J�vm�����]���f(e�4C�bJL�j�=zv�����n��+�ǽo�ox�pL�<ܖ�� �:�W��\C<�R>��������N 6� ���N�=T�=�Eս 58�H��>��#��$�D=�<��Z��=V2�=��@g��ٽ@b�=���=����,�=�u����&;O>���7:e��v?���w�	�ѓ�>�O5����\B?T(>���=��R�Pvx=�>Ђ�je��k-!��뢿�?B�c�'��0������o��n\=>q-!���q>�묾����6���);��I�>�=p���[�p>7�Z?}{��&{���F<>q~t�Iʾ��->޾�Aֿ��`@=���s<D��>���/J�lK`=A".���׾��5<�lP��\��44�:��=%��QYB���>X��?���Q���2U����=Z�F��=�H��@0���7R=H&D�1�<��g>�k���f$�ɗ~�k�߾��S>h�^��W�=��\�h��=fbZ�ā'��L�=3�j�)���ce=�=��7���������� �u=�!��rA��F�:�۽4�;q}3<c��rhǾ��������1���䅽EBV�8�μo{	���Z�z�O��! ���,�
������[=k&T�K�$��� ^�=Y�P��dA�+#����ŷ�`�&����>�7Q=K���b��@AҾ� ?���=&�!�}�\;��x��<X������:?٧�?X��i�5?b�̾2�=Y~����>�(���Ƶ���R�(4��D�>�����/^�%F(��Z������߼Iᚿ҅������7@��I�]좿+�=q<����O���[���	�:3�l���`R������˿��-��TǾ:�<�랿���e��xj�=�m��!DZ����q�9�h���}�v�,I=�3����	?g�Ⱦ(C*��b���;������'9�2�LRg�y/�Y!?��i> 0�>�Y�	ƛ�!N�>Y��=2y�����ۨ?�I�l���>m��>�~��I�Ҿ+aY>P����Qž%�����&���L�"(�72=�(�>��(���Q���Ƥ	�Ȣ>�e������s<x�n����W�i>�H>��b�T��{F?^��=	�=A�3���ɿ��=����?�jӿ��\?"�彃�J�F����ڽ��=�y�=T�h�󼿾()B�\����� ����=2~ȿ]����#>��	<h���ݳ5=����I*o��,=�Fſ�h�����Uى�n���=���=�ꗿ��f��	9?�<]>j�=������=�у>d�?�z �&B=g�������ĝ�Hk�=���>�nl�Ң{�{�0>�о�>�!�?�E޿�ӣ�Fh�=�(������nA9;;�\�K��<��g�d叽�����$�f]㽢�3>�<?�Oν�fټ���>� R��4
���m�r�#��t�#�<8�2>���=N�����Э�>ctK�y�9�b���;
NS>���*D�/e����>d�(��jh>p_�ǭ�����=�1�=T$�\{��Mπ�8�=�w��8��~�<�'��"�)Һ:�lƼ9����Ž�d�=��>�׽�A/��?=�C>���<rH>2�=-�=)�罨���q-��lW���?��{�5�2��� GѼP��<U"U>͘|��l辀R?gX�\�����W=����7��}����c=o�">A�=�ѽ��.<d�=*�<��K>��>�B���R>�	>��5=�Ne=�S�<����n����&���>��=p��MƧ�*��#<��lP=��h<f�=0�`=�H�;A��+�K*��$x=�N��^�,�DA=ѕ��18=��+C;�ӵ� i�i�V�Y%�=�y�hzj=�닽��=dV�;F�1����<B=\��rC�>�􋾲d���u���G2=W���w >��9�h����Կ��\=7�
>վ޲��� =�����;=��9�=�$R�r�<��$=�ڽiI�:��=�v̾zž8jb>u۫=_">�˄=1.G>�4>�H�>�s��i[��|�<o��zu>_Z�N�ۿ�H=c���.��;���>�A=}����yH��L�bǿd�=p�վ#-�]���p�o<پL�|H<b:?,�ɾ��=��D>t�*����=��'�w���/%�j� �$�칂\�Ǜ���R6>�^ �j�վ\~��,( ���=_e|���R��[��8����;�-����7����=�6��~%�6��:�Ts�>?��I��L��{ս��2��=��=�����h���\����o�DY����:ܶ�=:�d���9��[ 0�`,e��a!=3w3=k(s�.��=C��b�hq�����=o�<aw;=�������r�"?�Ь�0�������J��S���fg���]��q�e��?D.[=��;͖���>R��=�F��#=�����=�{w?PQ���䨿�����$������ĽRo�bф��>	k���վ��W�忥%���o�=�	Q;q��P%c�bc��VG��&,���?��Z��X��S�N>�w~�Pd��@���?����Y�N̬>X���+��=��E�T	Q��Y���>:ŋ�c�X�	E�=�m�u$?)~?3�(��Hr����>>���J}ƿ=�?�ި�#�>�#?��E������>�mf�!S?�
?�`��g�P�<۶��X���������R�6C��a�	?��j�Uw����A�I@�>P�Ͻ�@���>$�">l2X�S8���,�N3�>­>?`�
?�"�=m��3ˁ�X1��Q�нW�뼱��>�X�=3�䛟�v�8=�yx�=�3�QB+?�������4�=�j�߻n�f9��D`Ϳ��V���=��	?	6>�lN�KF���e�>�( �ſὗ�>��g������ƽ�Eƾ��ƾvrY@��?�Sտw�A?��?R��=�꼍O�������ƿ%��r5Ȼ�aL>4�����>�\,>�S��~Q����<Qc���ο-��=�?҉�>X��=ܚ�>R)�=(�%=���Pjj?��Y���0>,<�I>� ��"�=�#= +)����}�t>#�>�׾#kW��k��߿G<�+?3�=��k>%��?�%�>�ݡ>l�����<>�C�=;|�?졊���̾���֡=���>��=�֪�R~���B�d;�<f�E�l9�����Ξ�����9g����p���V�=I�����=�\="Rҽ���4]����9�s��=d!ܽK[ >�	�렽O�[=/�Ž��4=�!�A�=n�&�	$�=�s�9; ��Щ�q�;;S���=I����y�f�����#�q=X�̼��ǽy��LjR=�t�M
>��=̭<`�<�e�<�}=4 �̮;= p�=|ݽ���nj;p�����<{��8w3�#=��&�$�ѽ��=��=���<���v���a�Ľ��D=�MV=��=��=_V�������݂=8��<��@b�=�b(�m���+�=��1=���=���=�ؽ�L��� >0������޽&�/�W
>�"�H�?��W������z�=轢�,��h>� �z@�=��½!����<�N���?n�D�����@8̽
9���=壏�h��(��'��է!=造�[+f=�n)�Il��g��=J�)=T�ļC�\��?�
ν�kF�Vק�꺁���ƽڑ����=��>�i�i�mz���K�=pwO�m8�.҃=M��Z�~�U->ʠn=x��=0
>�X�b��ZZ������k=���;j9�=D�����K��2�w턾�	��<�8q��Tlf���?�iF�]�R>��ÿp�B<$K�-Ї�,r����=u�����(��娿��׾��)��W=?Z��>�B>�n>N����B����1;���$D>�*5������M>�ۗ?k�� ��6꛾���	�h�T�h>6���h?�)�>�Ő>츧�u���l	>"~;?���=Spÿxº����<S�<bm�>te>Q7>Ib<���y=@�P��ʣ��n>+�i?��<_>�경��<<��>�3"���>����Wb�=ej�=��+��ڈ�o��>��(���@�e d>in>�<���oʼ[Y�>L\	<D!>>��x_�	2��#��~��=3����H��o��k%=um"<ȯ�=p�Y<h�M��c=�*C>C������E�>�j��l�xڗ=6��<��=.��<+n)=�Ӯ�7ի=`�����.$\=Ӿ�=��b������
>	�<(��(       $�>���}\��ft��Tn��}�;>��Y�p�P>M�!�����ƾ��?yޣ>������
 ?A]ɽ�I;?/]?x����>9؍��^?���<��ֽ�5?�)I?bD�=xe�����[ӾI{!?�7�>C�,��u.�8���n�=��F?����&�(       2+�?��1@"<,��)J?�( ?;�?�����f��g߾
tS?�ݭ<SH?98�D�i��%֢?� y=^�?vv<��
��v��Pq�>�J�>�"�>կ�;s����?S�=A˿W���=&�d��Ӿ�4��(��=�?=���E9C��#�>���;