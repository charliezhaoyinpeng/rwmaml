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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2327161667248qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2327161669840qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2327161669936qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2327161667920q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2327161667824q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2327161666864q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2327161666864qX   2327161667248qX   2327161667824qX   2327161667920qX   2327161669840qX   2327161669936qe.       �Y�(       �����'�@>��J=�O�l>�/?�9L��i��<��M?���>Mk���B�.N�<�}m���5����k����'�RJ?���\̼F�3?�1�����A�����IΥ>=2!>�4=��/��d�p��-m ?��+?Yg��G���4� �(       �t��C������S�2��;�O�r���{ھ���_�*@�uJ?���И�>Uv?�m�?�ƶ>}>W�!Ҿ>Jd�l�Q?,1�>Z2?��5����>i���T����F�>~=�x�&?%����>T�>��]�V��>U@?G�����־���0�ƾ(       ���>�SB?�6�>\��w.�m�!�(:L=j�V>^�3#
?F���'�=j�t���J�Q?���<o٨��P��ۘ�\&�?��o=!&�l_u>�k�)н�N?�?أ�����z�>�?�����9ӿ������ھ�?}������)?d����T�>(       ��O��q��3Ϯ>X��Y~ƽd/Q��ܾ>�����\��H޿�y:��L����>��?3*;�����R��y��|������n:>�	�=������>�%���1���þ�ǂ�<��=|�=��<��>t�&>�o��G�
��>�ϿU�9��HN�@      aS澔=��/��x*�������>:��L��A����ㄽ/>����=�=�-��<`"��_@����=�a8�>�r����?PT)���>t>(�$�d�ݛ��P^4�ە�>�כ�?���Ie�=Ͷ�?MX?�x������$������AB�7��ot��'�>��m��y��D���k]?,�)����iV�I��a��kr`?:����o:�����W�J�`�=@���!-1���,��ľ�>����+�V��>�d������'�=��>��W?��?d�"=�\N?ut>G@K�k[��!ǿ��!B̿�Q�.U>;#v�W���!� �J<|о� J�3ڊ���辐B
��U�:�쾚R
>0 L?��/=�������&?>ɜ߽��Ƽ
6ľZh�ǔW?,���j��>M��W:t��|�=�@ξF<�If+?�$]�H��j�EK>��I���p轾�@	���9���ӽ@�����6���S��>�<���=��ɿfwR��3ܽ��w����Ͻ�5?+�c>D�ƽ2v���r!�_�Q���/{�= !>��=�?��(��'7�<y�I-=��4��J����"(?��=6��\�;�
]ݾy�s���v��=�:��E�F����̽�	��Q{�!S����B���oݽ�4�=U��<���a,��&?x`�>k�&������=;����l�����N7�$�Z�:��=lZ�?�9�.�[�-˄��/���Z�����@����RS��bԽ-t�.Hp��ɹ��)��P��v}���<૪<�uV��=B�=wʽ�i$��^=Y>�=ZLؽ�r>=�"�Z
U��,���
�)<�<
�c��\9��<T=�!K�e½��=��:�s��<�3����ֽp2>��Є�k�> �<X����F}�g�N�0�<�n���0��7��U����`	�>�>;�f>l=`�f�����=�A�>�]D�Z��=ʽ��w�2>�H>U�P�E=6>�{>3��=���0h���Ժ�B��Q�>�+�=��?8K	>aļ�N)1�'I�K%��R��>G��Ҿ�,��6�=o��
��=f��_4����>Η�..i������f���j�>4�6�<c��p݂�*ľ���=��;�9G���_�>7���[����v���Ծ�}��Yw)�*��?&ޫ�f�>���r'����OgQ=T;� �R�Z������0?Ua�?%&v�����RQ��Ğ���T��|l�����j߼�⽺��� �|���꽯���e�������t=����Н�⼧�+OV?��>0j�<L+��\�=y����>�m̾�����ɾ�W9��@�=������p���>m�̣��l �x����!c?^�ݾ��t=�b��_j�I$���=毧�p�k�k�V��ҧ�6�?˕��p0����>;�>�����
>��=��׽��j� f�=r��%���ݘ�yv`?sjս=�/�#�l�?$?��?�ԡ<Ǖ�=�B=M�Z�:[�:�\�m�>��H��m@?����P>�s�>c$�c��|l�0� �q��iS��+�:���>��>���[>��>.E���>�d�=�j�S���Պ����=Γ�=�<����<T��>�^�<
�/?3Ӕ>�,ݿ[����=����J�>=-y�>t�R=�H?��޽�q#�ܐ����m>q���=޼(�ּ�����j���>"����%p�>R�d>�����>�KJ��#�>hJ?�g%>q�?ך�?�k�����(q?	
?���>{���{�=�� ?�5�x?i��>X1�>���=�n ?�e�>9?Z:�����Pq���*�>��>D�)���o����>�
E��%>cr��>�a�*�ڽ���:U�>��_�%���R�� 6T�#���q����;���M�=wȽ)�b=ntr�BT�����p��=x��<�^����]>[��/
�
����5
ٻߟw����OW|=�TC?/�:��ݱ����>̈>k9��;(�X&��Ðľ��>�E�=�d��^>ؠ�>��>�J8�����t<�
Ͼk��>�(�ډ��t�>16���
$<�䋿)3����Tr���D�?��$>`Ϣ�_ǘ>�^��w��=t�1�
?{ o?��/?��=(
�d�{?�i>��s�8���&��Lb����J�p!��2q�>@_�<B��`r�v.�=��,�|��''����=�+徴�N������?45?�G=
��3|ǿ\�R�"��(�{�uQؿ�3+�r=��LV?�LM�ܲ����G�<�þ޲�<&S����~���?F���鈿�����������0۾iؐ�C7�?bUX����I�=>��=�����r馼2Ű��ᴽ���ʾ�ㆰ���>��?�]��	��<���~$E�=OW��/��d���̻����k�?�@�S=��!����"׽� ��>�>"�W=oٽ
�^��O����><���>����cl!���h��1�=�2z=fW��Xm佬D
��U>�KJ����)W>>`孽�#P>dU���E7�>�>>��m>=p$>�s��bq�;���>��<��6>8x�>T�C��>�->`x�=�g=禾�+-?~��=�{?�Ԗ�7��=!�=y��>����y����z�F/�=gw1����=uU��X��<�Pn�}��>��홽 �Ļ�����DI�%ز� �>g�Y?��n����{N4�(������f:����@_Z���?�~u��ž�o��EYƾ�̐>Z���׿�f���K?b��?%)��hz�r����Θ��:���/e��#f>p��<4T��{8	>�Լ"�0=��ɾȜ)��k>�Q$>�>�����>Hr���9���>�4>��>�<�32��U�N��?[>�H>�~�c�)����=6s�=��q<ly1��y�MRj?�=��?���>��> L��;��(�����վp���S�>�!�([���Մ>�«�?ay�s������������=�h�r��9m�����[y�T�C>�*�<Z}��D ���i����>���>��?��"=�������Ѿ<�q>D���Ν= ?P�c>��[�M>͙�?}?�_S?�?�uҿL6�!�>>v�(���$�x>4J`=���A�m��`�=,�$���<RF�5�k���~�_��?R��?A���.J���ƾ�a�\E��=ɿ�����")���ۿ]�e?&(���оB�J��"����K� ��n/ ���C�� ��j�<���������)�������>p�%==?�NU����b!>�VZ?�˯���=<���Wr!>�ly�>f�=�s��t~0=k#�;������ݿܯw�~V?��?�����>�?�S*��R��}����;����%��8s>�n�?(&w>S�����>x�>�
?(����%������q-M�w��Օ�=�<C=u.x>���>%��>��%�U >AE��,�|>7Ͼ����<&A�,�w����g�¾�P���L�y�3��b4?�"?�e��2��.z��Z�;���|[?eN]?g�T?�B��}�v���?���b���KK�徼+[�$0�Ⱥ��;�� �="I��x��<�1�4��=4����;��F<E����� ���>�^?��7>��@=�(]�0���7��h>p�&�?y����,�T���D?lJ�=(����Ԓ��$2�"=��nѹ����:�f?�gM�ߠ���휿�Mƾ�'��=)��_>��d=|3>�>��;�=�=���YX>��=q��e˽���Y��>J0�B�=9��=�}g=*-����P���N��].������>>�<�ni�,a
?�D9���3�	�߽��>�(�>�~�>��P>V�|�_z.>����s�(�����R`6���2�s�b�t0�,���ŕz�K���3]̽�σ�Kͭ;P�ξ�o<B���m'=�%��<���X�JLj=<D��"���Ͻ������=�?�<�06�̅ݾ��rj"�}���+�=S��=�3�z$�> >k��>�1>�u��P��=���c۔>�c�%�ξ�*���;�3�:���� �;a->�=�ɾ�پ��ӽ���8�?�!���x}�B"Ͼ��V��!�����;��������m?`���e������j���h�y�0�ѽ���>u�=��N>h�^�\e�?sPF?�Z���5ҿ�H9���>�3ؾ����
��N��N��=�/�� �`�7n��E��)���Q�>�k��q=>=YV�n�=Yj6?��@����=�.�=�>�P�>,�>"��YC���_�?�%f���9?��_>��E>A�4>mܨ=?j���B���Y=`4ֿ����D��=H�7>��>��ؽ�!>�_0?��I>���<A��������Լ�i�ȝ������Nٽ����v��M��T��q?U&�> �L8:�����\=rL�=j �=4?|>L����y=��V=S�?땽F(�H=(l���x���.��aȰ=����w>�K����0?W��>�2�Ȋ��G�ýd��=�Ƚ�7�=KMv�9��<�,��C���B=�	n�� �=xK2��2���4�NĘ?w��?��=ÎG=6���rj���?��n���0���=���ڽW��>]߮�)X�/��<��>=�=�r��W#�,]�@|���c������@�m���^��':���Ҿ�J\>�N�=MN�>��醩?]������?����m=��־ç�?`�o>�4��1�토=�2P>������h#�����/Z����?&�ʿ�29?]m�ޝ��~m����>���?[K�?�}=���[E����m������C>�V��J�8S�>��@�V<h�;��#��<�&}=�����^��e�=>s���->d�=�K�����~�鼦�= Y�<�ɽ^D�����>���h���}=�%���>��-w��� ���R>�w�����S�!�
?r?W:{�;+/�{��>Ŵ�>��<h��=�*��$� ��>>���G1W�8��<��쾻0�>�����f�=�s=�	?Ω̾,�> ��k��p�q=��=9�>��?@�>h��>�^n���?0X? ���>l?@U�=�˽ ���� @et�{˃��XϽ�{c>�3Z��>�޸��iW>;&�����>"۽���T���	>$`���+p��:t=��I�@ql<�Xp�6]��l���ss=�s�o>:�U�I�J@޼.�b�=����ba�ג�[�L�w�|������]��4������O�l���Z��7���;�<ۺ��#i� �	�U:�ҿ
>�^�����SY����0j]�:��h�=b��>U#>��m
b?v����g>���=	�=���< >��X��@=��R>S-�>�_?�2��,����z?T���nl>�s>�y�>0*м]C�>�i�?��?aG�]��v�оL�>g�������\m?[w2?R�>2�=���=��L�9���
>�YE>���y�>P��<CD�0�>Q������
���	�\=�������ٵ<��y=��|�-�?!A�;׎��w=� >k����>��h>;9?�>�Ƶ���n= Y=`[����u�\֛�R�h�H!���%=b�=���=B_���v#��0�� i�=��� ��=ذ�@=v;)𐽩>Kz���-=�����*�ܾt����=���=cw�����~��V��:���H���[n=J��R7��֖=�������pc?=f�����=�)!�db�=���:e�>��>���<p%+��#�>x�<�g�K�X���>�@'�v� �Q猾:����x=+��+�4�'w>;��=0_5����>[���Y�t>�ș���>�L	�U�>��ѽ4 ����|�����G+?��>���=�&MM�	G�<�A1?C-�> h�>֘�x�Ͽܗ�>��5z	�z��h���:R�%�a��0�= r���Ř=��-�D�@BG=��r����|<e�	>���� ���>H��� ��;����W�fL=������>�3;�Tu����j�%��\�=ᒵ�#�� ]�<�[v�;��Ľ���xc]��(�=�N��=� ���=�{C=���=yu���'W�P���GP�¥�=7�|=��>D�j>OL������*=b�b��\�<Ѡʾ:=��'�?2��k�>@��=���*�N����=C����[?vvm��4���GM��U���N�⢯��C��X$��^�/���