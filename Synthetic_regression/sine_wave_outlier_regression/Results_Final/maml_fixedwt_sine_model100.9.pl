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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_fixed_weight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_fixed_weight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2129170705024qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2129170705312qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2129170703584qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2129170705120q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2129170705504q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2129170702816q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2129170702816qX   2129170703584qX   2129170705024qX   2129170705120qX   2129170705312qX   2129170705504qe.       2�@�@      g#�K3�>6�6>�k��������<4��%���N?j?�b'?��
�JE��,�>7q�>r���n�>k��>g�e� �?Tg�t�M�cg¿�<�>�c5�u�W�q��>�܇>ˆ����<�����9>��C��+ ��o�����> ��D	?�:�>��齈s���Ď=@$=���=n_=�7�=���wX���^=@�Ȼ�a�=a����-��ݸ=z�,�hv���w:��Z=m�/�<y��_\�vZe��S"<��0�K+��7=q�;z\�YF!��p ��p�)]�ϩT=G�=�6�Zz����<�>�����X=�L���*��*?"�ռ�z��Фa��,�B��=P�>�q��J�HUk?L���=�ʱ�dH>ϝ=>�̦�����D�����m���{�>%���d�?�f��&` =W����ay��m���tɾ$uǾ�MY�8,�?�4=]����þ,;�f���^;��%��>'�x=���÷��Q�8��ˏ�u���WȾ1p8�ԁ>o�J�\���½�By�|��@�A<�=���5}x�0L�������L�����R�ž��������Wz��lM����+}h��	>�����&ñ��TE=	V?����:a�?,�.>C�=g`M����O�����j���&>��=ӷ��P�<U1,='x������=��6��;�h뻼3�=N��=48+�u\G���>9�C��0��]����2��u}�^���EI�
E���>�z���V��d�����;���t��P��7�����Z˽�+����ɿۇM��v9���a=�K��b��<p���>D^����{!�������m��jc$���۽��0�=��"=�V�<T4�g�=�6��~տR>�#=�"�PB&��I=�(J��=��4=P>R1�=���>%Ƀ��`�?��P=���G|�=>t>S9}>��'�a^x���:>���<�"~�H�T�Q��>N���ilk?��>�s)۾�E�Fy�>����pBp��=Z���x��nŽ������	����ل?d�꾮���D�}d��cC��I>���`<�M���n<�&���-� ���-U�>�Ξ>rM�=_����>J��h��.S$�S�>�'Z����|z?44��@�>�
�ŎͿ�{��Q^>뾾��ڪ<�M������?�p�Ŗ��4m�_&!?K�p�����B>紽��5�3�O�}^*���!��u�=��0�}�O�R�o瀿,G,>=�>zpp��N���\Ž;����hὐ�=`��;���=g'��$��>�����#.���0�=��Q�I-7���;�Ɯ�$�m����=�1�VI.>�,Ƚ����Yȣ�d}=^u"=��.io���D;�n��u�߽�̥=Z�*=?dÿ
��0�ؾ��>V;2>��=��(>������������`�=� ��i�=���s?��q<�ￔ��=^��N�T��R�=����m�� ��;J̈́=Q���ɉ,>�z�h��<����;K��GR=k��٪ؾ�#6��>>��=�ܽ�>��*<;�����7�㧤����<m>�����)��,�=�S>{c�������<p9�<�t�>6�s��0��f1�=m����x=�� ����q�=�!������o����>9�!>B|�=�b���!���s���>������=@j>��������<>Y�>"G��~�?<�c�K\>!��-��4�9>)��=���>����T酽}2�;p� �p�=B����듼G�$����������C=n%�1�:�)C���;SA��>��x�`?�+�>AD > D�=� ��t�����=P8C�{�μ��� C�^�˽oo���D�+���v���:,	;�?��J�=�54=_z=��=��M�����!.��M=��G=;��$J���:n*.��O��g�<co>l�f�nN:�@(J��C���y���䭾@�Ǿ��@�p��<��)��mV> ��;��g�,���;�{��������+i�26$�R�{�~�۽�2�Zd��7���n���
��a���7H�J�m=IZ�=������� >�/$������{E=K��{o-�2}=��ȼ��X=]����=u� =J�P
�<.
[�R��E�7"ս�ϝ=�	�����à�GBѽ�k�<�03�0�r=�w�����l�=���<�&�,u#�g,�=�v�=�	J�������#�`d���>�4�>�=��~;c=䢗�Cg=G�Ҿ��ռ�iݽ�Ę�>�f���:<�Ľ�Ƚ	�>�ٞ?m��=Ym��Q���Md�(Û��l>^�.�����be� X����>�2���A�>Р7<�O�?�^���,?̋��w$���=S�=�G¾��s��Ƚ'�<�=�QQ��m8�Z!?�P��L����=���^�=�e�ŻX?�0]���<yO̿���|ʗ����=<W��&��½ę6���T�����!.>`�=��i���=�3��^�����<^��>Q=n�>l���}�<��7<g˾2��jx
�%>����QC���E?����m+���D�c[>:�ܾ��%>�����֣?�3������忲k�=���<Br>+��<��+��%w�(�=m���#�Z��<AE����\`�*���ƽ��B��U]?����\=�����n���߽��=PR��ҳ=�Ć=p�=Zw��W�^�=�f����=56x=*�u�>�h&��!�>J���b��@=�_�ý��=�[I���i�XYV� a�:���T՞=�9��v���uɼ�����B=#�� K��A�=���3�<x;�=$�a���0���'�qb=^� ��qF���7;Q������C���>Y"��x3���� >�V��W	=dӻ�`�=�Y�=�4�=h��ԇ��䃽u齽&ʽ����;�[�4�C�.<p陽���= ��lM)=tt4=�E=�+�~����=n���>蒾�Gf>�a�=�7���ɾ41=,����$y?��X�
���h'�t_��h�>}h=:�V�;��o=A����{��	t��G��r�9���+�t�3�_�ǿU�پ��\>��O>�k��3����_��9��n�.n���&?u��=
�t?�ƥ�1J�(���>��o�=Ggo������E>����=�N?4̣>�a
����=�<���Խ]�>��cB��$�=x���3�����>Sx�?�{���'�>�H?pX��FqĿa3�>��ƿu%���BE>o��!�>Y�D�]t?M"�_��?|
�����?���b�j���&�X��<vO.�5#W�����彀�h=z&���h�V�=Z��A~ܽd᣽K����?�#����!�G�r�2빼"��y�8�a=C岽$#1=}����F=1���o����U����<�@�=;��̵$=؟�=?��;���=�[���M�<�k�08o<v[ξK�=*�H>�C�����<3�=!�D=���ؼ�}ɽ�����[��Q�->�!�G���^�`>"�>��ʽ ����I�؅O��E6=�6[��3쿎��=ߎ%> ݈>H�q>������f�>����/=�d��v�>��T>���k���;Ƒ=���E�=$,G�!L�=P��<�C)�%Xo;
�O�P�B��u��Ā�=|���U�=�ދ�y�W=����
�6������=�C<OIn=D ��A���u'�'J ����<�b@��n�<��p��,�軥�q��Eg"=�+%>����m��ؼ�h���1�>�恾 VF�p���0�=2�\ہ?��ѽbf��}�>��kg����>.о}8߾�ș����o0�#�u��=����/M�>鈿�Z���x%�����-{�'P>�wm���x�����(�r?I~L��7?�Ք>u�>p�s��*�=o@3>�������g8=t�x�8�>��'��v>�⥾�=Y:���>�U�&{_=��6�k|�<���qپ�D?��>�>��@>�!	�S巾�Up�l�=zS�; hάTQ�6�@��q$�r1� ����뿔��=퟿��=X=�(�.>T62>VX�=p����y;�d\�>lJt=d=3����?���<��!���~>�����m���򾓛�>I��d���X��Eh�=���c��RD�M�����0>���B��;13�����Y���Z>#-�oP��Q>�M��S�ǽ�Or�T��>a�>���>T�����g������O=Ӵ>�z���=@��<���=��T=�u9<SV$��L�@�<,�ѽ:ս�E�=VJp=ty���*���<n ��6�������X<=�/B=IQ�=j�;r��<�?�"�����罃��p��<4���:�)<�c5��t���H������ٽz�;[ͼr�I��?�`<
=���<cl
���'=���;x�k������mٽ���<1T��j�8��1���q�_�_�p <d�=F��RN��'����='���Ni��l������һ��^��H{��5�;,����罻K7���~��=�ݽ�n~=�O���=�C���b�C\>�~m��V���X�S*��*�2Gb�3r�by���岼ȑ�=� ѽu����f9<xN�;�Z`��[�=����)���ǽ3߼ ��!�<������cd�P���`S����P�꽟�ＰF<6_�=�<�J=��"�X���*�ajg�>eo�B`'>����н@O���t�>�A�=[6���(��T�="��=O|�=�F��g�>>�]0���=��2�a�6>B��=��n<� m��7���=o�PtJ������!=����[q�����V =��e�&����ռ[�[�5=R�~
�=pQ:=���P��g)?\�ɽ����ہ=��� ��m�>�>&>���&>����	8=@C�>����*�=�H(?�:a?�3>�*>��@=%%�>��=�P?P����3�3�>4��<�Z?PE��5W?�Mh>���]�P�̬��-�<��D%�I�>�=��=q|q���6���ʽ<:�l���~��>'�:���C��6�j���f;:�<.����!�_�y��)��A{�E9��9,���k=Qkl�cDg=����4���uM��M��� �?�b�>͖�2^�����B�� 0���?�~d{��1������=([u��F�<\�E=��>�O�u!>ظ2�'QG>�S��� >�E;��n�=�0����G���&�Ռ)�B@%�&�.��	>&᤾�~���;�=��*����i�p���>w!=<Ք��j�=hb�,�>9�ih*��>DP��ù��J;3�ľ.}/���]=J9���>�w���옾Wx	��A�=|����%>����=Iw����>�K:"�^��Y��0�>!��=R�ƽ ���"����E��Bs�eZ������/�>���|��������<d�=���9���z��?0�ھ�ߎ=
����>y��C�24O�i�[=�a?UZ��qm�</7>o���O���0��S!?8*���������Y�<z{����<,ҽ�e��=4�"��8=��̿�����E�ɲ>/�\>! j����x6ʽ����	�����=m�$�	3�p�̽;A�_������o�<�}��=��=�5$>�?z}u��:�J��9P�?`�?=Ҏ�J��mii?��*�W�p�����$��цK�<�k?㠔��у��S��@�=�V?lL��"?!��Sǿ�U����>�r >u�m�Q���o���M?P����*������)s�r��fmd������?�΃?;W����üWξ�x�-I�^�3>���"D>�<uE�>�Iv�'}?U���<�s6�-4>?����?پ��A|��d/'��Og��4">nH>���>f]ཎ�F��k��5��X�^���>3�C���+=����c�>��ҿ~.���H¿+������=��>G��8|>R�
��ƾi`t�0�T��E�)�a�"�!�#Ԯ��O�>�Aݽ��h�|Ƚ=x>��=�r�;��ֽ�ս xq��s��3	���u�f~�>�1���#5>��v�o	��G
����ܪ��7?��2?#\ϼǋ���rվ�2�b����<�k�>E�>� �l�+�>-�B?�� ����D�d?�>�Aa�z��X%�=|���y?"A.=A:���6Ž�#�>
�?�*���L(���^�����𲔾��>�ݾ�M�=�<bd}?篇>������>4��P|��Y��޾�I?uR?POͿ(       f�>����O�	H��r?
>ӓ�>}6��w��=3A��^���dx�>D���*�>��j�T��c��N/��N4=�-?�)�>=.�>��̽���\��7Ƚ~̖��^%��}�>�o;�Zp�5��܇�>�/D�����_�)��� >��M>��Y?(       �U?Ӗ����=1�.?�����>�>��>d��n�z>��`)����=��㽡�(�os&?*�6?_�8;�"Ӽ��	��-�l&�������
ݼ�4?�޾�z?��=��ό=�}���!��^<�,|꼟e���|%�����Nm?��%��@��M��(       �\��(?�Qz�Le������f���ȿ1��>��>x�$�D?*���:����X��N��=̖5�_�;ؕ���ѿPjT>����oZͿ�Z˿^?�<�%o�o�=�,���N��������+r�1���vO�6"@?�P�<fK?!���=	���(       � ��5��.�VT�}d�BL���?��F�=@�=�>K��=��>��.��f������4>D�>��	�V�=:�?���?b�P���=�iI�_�?��>"f-?�).��|�>�"%�Be7>9>?�"X>ն��l��y�>�W��?�;���1�